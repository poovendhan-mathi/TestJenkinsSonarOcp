export interface Expense {
  id: string;
  name: string;
  amount: number;
  category: string;
  date: string;
}

export const CATEGORIES = [
  "Food",
  "Transport",
  "Shopping",
  "Bills",
  "Entertainment",
  "Health",
  "Other",
] as const;

export type Category = (typeof CATEGORIES)[number];
