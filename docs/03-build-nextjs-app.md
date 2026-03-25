# Step 3: Build the Next.js Expense Tracker App

> The app is SIMPLE on purpose. We're here to learn pipelines, not build a complex app.

---

## What the App Does

- ✅ Add an expense (name, amount, category, date)
- ✅ Delete an expense
- ✅ See total spending
- ✅ Filter by category
- ✅ Data saved in localStorage (no database!)
- That's it.

---

## The App Is Already Created!

The app files are already in this project. Here's what exists:

```
src/
├── app/
│   ├── layout.tsx          ← Main layout (header, footer)
│   ├── page.tsx            ← Home page (expense list)
│   └── globals.css         ← Global styles
├── components/
│   ├── ExpenseForm.tsx     ← Add new expense form
│   ├── ExpenseList.tsx     ← Table of expenses
│   ├── ExpenseFilter.tsx   ← Category filter dropdown
│   └── ExpenseSummary.tsx  ← Total spending display
├── hooks/
│   └── useExpenses.ts      ← Custom hook for expense logic
├── types/
│   └── expense.ts          ← TypeScript types
└── utils/
    └── storage.ts          ← localStorage helper functions
```

---

## Run the App

```bash
# Navigate to the project
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp

# Install dependencies
npm install

# Start the dev server
npm run dev
```

Open **http://localhost:3000** in your browser. You should see the Expense Tracker!

---

## Try It Out

1. **Add an expense**: Fill in the form, click "Add Expense"
2. **See the total**: Watch the summary update
3. **Filter**: Try filtering by category
4. **Delete**: Click the delete button on any expense
5. **Refresh the page**: Your data should still be there (localStorage!)

---

## Run Tests

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:coverage
```

---

## Understanding the Code (Quick Tour)

### The Expense Type (`src/types/expense.ts`)
```typescript
// An expense looks like this:
{
  id: "abc123",          // unique ID
  name: "Coffee",        // what you bought
  amount: 4.50,          // how much it cost
  category: "Food",      // category
  date: "2025-03-25"     // when
}
```

### localStorage (`src/utils/storage.ts`)
```typescript
// Save expenses to browser storage
// Think of it as a mini-database inside your browser
// Data survives page refreshes but NOT browser clearing

saveExpenses(expenses)   // Save
loadExpenses()           // Load
```

### The Custom Hook (`src/hooks/useExpenses.ts`)
```typescript
// All the expense logic in one place
const { expenses, addExpense, deleteExpense, total, filteredExpenses } = useExpenses()
```

---

## What About the Pipeline?

The app doesn't know about Jenkins, SonarQube, or anything else. **The pipeline wraps around the app**. Think of it like:

- The app = **the pizza**
- The pipeline = **the conveyor belt that checks and delivers the pizza**

The pizza doesn't need to know about the conveyor belt. It just needs to be a good pizza.

---

## Checkpoint ✅

Before moving on, verify:
- [ ] `npm run dev` starts the app at http://localhost:3000
- [ ] You can add, view, and delete expenses
- [ ] `npm test` passes all tests
- [ ] `npm run build` completes without errors

---

## Next Step
👉 Go to [04-jenkins-pipeline-101.md](04-jenkins-pipeline-101.md) to set up Jenkins
