// Package cache provides a thread-safe LRU cache with TTL expiration.
package cache

import (
	"context"
	"fmt"
	"sync"
	"time"
)

const (
	DefaultCapacity = 256
	DefaultTTL      = 5 * time.Minute
	CleanupInterval = 30 * time.Second
)

// Entry holds a cached value with metadata.
type Entry[V any] struct {
	Value     V
	CreatedAt time.Time
	ExpiresAt time.Time
	HitCount  int64
}

// Cache is a generic thread-safe LRU cache.
type Cache[K comparable, V any] struct {
	mu       sync.RWMutex
	items    map[K]*Entry[V]
	capacity int
	ttl      time.Duration
	onEvict  func(K, V)
}

// Option configures a Cache instance.
type Option[K comparable, V any] func(*Cache[K, V])

// WithCapacity sets the maximum number of entries.
func WithCapacity[K comparable, V any](n int) Option[K, V] {
	return func(c *Cache[K, V]) {
		if n > 0 {
			c.capacity = n
		}
	}
}

// WithTTL sets the time-to-live for cache entries.
func WithTTL[K comparable, V any](d time.Duration) Option[K, V] {
	return func(c *Cache[K, V]) {
		c.ttl = d
	}
}

// New creates a Cache with the given options.
func New[K comparable, V any](opts ...Option[K, V]) *Cache[K, V] {
	c := &Cache[K, V]{
		items:    make(map[K]*Entry[V]),
		capacity: DefaultCapacity,
		ttl:      DefaultTTL,
	}
	for _, opt := range opts {
		opt(c)
	}
	return c
}

// Get retrieves a value from the cache.
func (c *Cache[K, V]) Get(key K) (V, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	entry, exists := c.items[key]
	if !exists {
		var zero V
		return zero, false
	}

	if time.Now().After(entry.ExpiresAt) {
		var zero V
		return zero, false
	}

	entry.HitCount++
	return entry.Value, true
}

// Set adds or updates a value in the cache.
func (c *Cache[K, V]) Set(key K, value V) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if len(c.items) >= c.capacity {
		c.evictOldest()
	}

	now := time.Now()
	c.items[key] = &Entry[V]{
		Value:     value,
		CreatedAt: now,
		ExpiresAt: now.Add(c.ttl),
		HitCount:  0,
	}
}

// StartCleanup runs periodic eviction of expired entries.
func (c *Cache[K, V]) StartCleanup(ctx context.Context) {
	ticker := time.NewTicker(CleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			c.removeExpired()
		}
	}
}

func (c *Cache[K, V]) removeExpired() {
	c.mu.Lock()
	defer c.mu.Unlock()

	now := time.Now()
	for key, entry := range c.items {
		if now.After(entry.ExpiresAt) {
			if c.onEvict != nil {
				c.onEvict(key, entry.Value)
			}
			delete(c.items, key)
		}
	}
}

func (c *Cache[K, V]) evictOldest() {
	var oldestKey K
	var oldestTime time.Time
	first := true

	for key, entry := range c.items {
		if first || entry.CreatedAt.Before(oldestTime) {
			oldestKey = key
			oldestTime = entry.CreatedAt
			first = false
		}
	}

	if !first {
		if c.onEvict != nil {
			c.onEvict(oldestKey, c.items[oldestKey].Value)
		}
		delete(c.items, oldestKey)
	}
}

// Stats returns cache statistics.
func (c *Cache[K, V]) Stats() map[string]any {
	c.mu.RLock()
	defer c.mu.RUnlock()

	var totalHits int64
	for _, entry := range c.items {
		totalHits += entry.HitCount
	}

	return map[string]any{
		"size":       len(c.items),
		"capacity":   c.capacity,
		"ttl":        c.ttl.String(),
		"total_hits": totalHits,
		"utilization": fmt.Sprintf("%.1f%%", float64(len(c.items))/float64(c.capacity)*100),
	}
}
