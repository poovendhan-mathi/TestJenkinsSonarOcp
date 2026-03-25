import { loadExpenses, saveExpenses } from "@/utils/storage";
import { Expense } from "@/types/expense";

// Mock localStorage
const localStorageMock = (() => {
  let store: Record<string, string> = {};
  return {
    getItem: (key: string) => store[key] || null,
    setItem: (key: string, value: string) => {
      store[key] = value;
    },
    clear: () => {
      store = {};
    },
    removeItem: (key: string) => {
      delete store[key];
    },
  };
})();

Object.defineProperty(window, "localStorage", {
  value: localStorageMock,
});

describe("storage", () => {
  beforeEach(() => {
    localStorageMock.clear();
  });

  describe("loadExpenses", () => {
    it("returns empty array when no data", () => {
      const result = loadExpenses();
      expect(result).toEqual([]);
    });

    it("returns saved expenses", () => {
      const expenses: Expense[] = [
        {
          id: "1",
          name: "Coffee",
          amount: 4.5,
          category: "Food",
          date: "2025-03-25",
        },
      ];
      localStorageMock.setItem(
        "expense-tracker-data",
        JSON.stringify(expenses)
      );

      const result = loadExpenses();
      expect(result).toEqual(expenses);
    });
  });

  describe("saveExpenses", () => {
    it("saves expenses to localStorage", () => {
      const expenses: Expense[] = [
        {
          id: "1",
          name: "Coffee",
          amount: 4.5,
          category: "Food",
          date: "2025-03-25",
        },
      ];

      saveExpenses(expenses);

      const stored = localStorageMock.getItem("expense-tracker-data");
      expect(stored).toBe(JSON.stringify(expenses));
    });

    it("saves empty array", () => {
      saveExpenses([]);
      const stored = localStorageMock.getItem("expense-tracker-data");
      expect(stored).toBe("[]");
    });
  });
});
