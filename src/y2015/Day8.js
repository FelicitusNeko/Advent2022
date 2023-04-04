const { readFileSync } = require("fs");
const { join } = require("path");

const d8input = join(__dirname, "..", "..", "cache", "2015", "8.txt");
const d8data = readFileSync(d8input).toString().trimEnd().split("\n");

const d8p1data = d8data.map((i) => {
  return {
    original: i,
    parsed: eval(i),
  };
});

var diff = d8p1data.reduce(
  (r, i) => r + (i.original.length - i.parsed.length),
  0
);
console.info(diff);

const d8p2data = d8data.map((i) => {
  return {
    original: i,
    escaped: JSON.stringify(i),
  };
});

var diff2 = d8p2data.reduce(
  (r, i) => r + (i.escaped.length - i.original.length),
  0
);
console.info(diff2);
// 1485 too low