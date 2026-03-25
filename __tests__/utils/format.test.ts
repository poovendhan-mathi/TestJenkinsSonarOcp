import { formatCurrency, formatDate } from "@/utils/format";

describe("formatCurrency", () => {
  it("formats a number as USD currency", () => {
    expect(formatCurrency(4.5)).toBe("$4.50");
  });

  it("formats zero", () => {
    expect(formatCurrency(0)).toBe("$0.00");
  });

  it("formats large numbers with commas", () => {
    expect(formatCurrency(1234.56)).toBe("$1,234.56");
  });

  it("formats whole numbers with .00", () => {
    expect(formatCurrency(100)).toBe("$100.00");
  });
});

describe("formatDate", () => {
  it("formats a date string to readable format", () => {
    const result = formatDate("2025-03-25");
    expect(result).toContain("Mar");
    expect(result).toContain("25");
    expect(result).toContain("2025");
  });
});
