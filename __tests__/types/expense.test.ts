import { CATEGORIES } from "@/types/expense";

describe("Expense types", () => {
  it("has expected categories", () => {
    expect(CATEGORIES).toContain("Food");
    expect(CATEGORIES).toContain("Transport");
    expect(CATEGORIES).toContain("Shopping");
    expect(CATEGORIES).toContain("Bills");
    expect(CATEGORIES).toContain("Entertainment");
    expect(CATEGORIES).toContain("Health");
    expect(CATEGORIES).toContain("Other");
  });

  it("has 7 categories", () => {
    expect(CATEGORIES).toHaveLength(7);
  });
});
