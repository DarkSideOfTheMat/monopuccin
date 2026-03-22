"""A small HTTP client for fetching weather data."""

from dataclasses import dataclass, field
from typing import Optional
import asyncio
import json

API_BASE = "https://api.weather.dev/v2"
MAX_RETRIES = 3
TIMEOUT = 30.0


@dataclass
class Location:
    """Represents a geographic coordinate."""

    latitude: float
    longitude: float
    name: str = "Unknown"
    tags: list[str] = field(default_factory=list)

    @property
    def is_valid(self) -> bool:
        return -90 <= self.latitude <= 90 and -180 <= self.longitude <= 180


class WeatherClient:
    def __init__(self, api_key: str, timeout: float = TIMEOUT):
        self._api_key = api_key
        self._cache: dict[str, dict] = {}
        self._retries = MAX_RETRIES

    async def fetch_forecast(
        self, location: Location, days: int = 7
    ) -> Optional[dict]:
        """Fetch weather forecast for a given location."""
        if not location.is_valid:
            raise ValueError(f"Invalid coordinates: {location}")

        cache_key = f"{location.latitude},{location.longitude}"
        if cache_key in self._cache:
            return self._cache[cache_key]

        for attempt in range(self._retries):
            try:
                url = f"{API_BASE}/forecast?lat={location.latitude}&lon={location.longitude}&days={days}"
                response = await self._make_request(url)

                if response["status"] == 200:
                    data = response["body"]
                    self._cache[cache_key] = data
                    return data
                elif response["status"] == 429:
                    wait = 2**attempt
                    await asyncio.sleep(wait)
                    continue
                else:
                    return None
            except (ConnectionError, TimeoutError) as e:
                if attempt == self._retries - 1:
                    raise RuntimeError(f"Failed after {self._retries} attempts") from e

        return None


async def main():
    client = WeatherClient(api_key="sk-demo-key-123")
    nyc = Location(40.7128, -74.0060, name="New York", tags=["urban", "coastal"])

    forecast = await client.fetch_forecast(nyc, days=5)
    if forecast is not None:
        temps = [day["temp_high"] for day in forecast["daily"]]
        avg = sum(temps) / len(temps)
        print(f"Average high for {nyc.name}: {avg:.1f} F")
    else:
        print("Could not retrieve forecast")


if __name__ == "__main__":
    asyncio.run(main())
