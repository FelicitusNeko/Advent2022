# Advent of Code 2022 Engine

This is FelicitusNeko's repo for the [Advent of Code 2022](https://adventofcode.com/), this year done in Haxe. I'm also doing 2024 in this engine, because the one I tried to make in 2023 was kind of broken and I never got around to fixing it.

This will retrieve data from the AoC server, or you can manually build the cache.

- **2022 Final score:** 46/50 stars collected before 23:59 EST on Christmas (beats last year's 45)
- **2024 Final score:** 40/50 stars collected before 23:59 EST on Christmas

## Automatic retrieval

Add two files:
 - `/secrets/useragent` containing your browser's user agent
 - `/secrets/session` containing your login session with AoC as specified in your browser's cookies

The program will then retrieve input data and store it in cache, under `/cache/[year]/[day].txt`.

**Note:** If you attempt to retrieve data for a day that has not yet been released, the program will attempt to detect this, and throw an error if it does. If it fails, the cached file will be a notice that the data is not yet available, rather than the actual puzzle input. The program does not check for this subsequently, so you will need to delete the file from cache manually.

## Manual retrieval

Simply retrieve your puzzle input manually from the website, and save it as-is to `/cache/[year]/[day].txt`. For example, if you want to run the data for year 2022 day 1, you'd save the data to `/cache/2022/1.txt`.