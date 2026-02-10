---
description: React component patterns with TypeScript examples. Composition, compound components, custom hooks, Context+Reducer state, memoization, code splitting, virtualization, error boundaries, accessibility, and animations.
---

# Frontend Development Patterns

Modern frontend patterns for React, Next.js, and performant user interfaces.

## Component Patterns

### Composition Over Inheritance

```typescript
interface CardProps {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}

export function Card({ children, variant = 'default' }: CardProps) {
  return <div className={`card card-${variant}`}>{children}</div>
}

export function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>
}

export function CardBody({ children }: { children: React.ReactNode }) {
  return <div className="card-body">{children}</div>
}
```

### Compound Components

```typescript
interface TabsContextValue {
  activeTab: string
  setActiveTab: (tab: string) => void
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined)

export function Tabs({ children, defaultTab }: {
  children: React.ReactNode
  defaultTab: string
}) {
  const [activeTab, setActiveTab] = useState(defaultTab)
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  )
}

export function Tab({ id, children }: { id: string, children: React.ReactNode }) {
  const context = useContext(TabsContext)
  if (!context) throw new Error('Tab must be used within Tabs')
  return (
    <button
      className={context.activeTab === id ? 'active' : ''}
      onClick={() => context.setActiveTab(id)}
    >
      {children}
    </button>
  )
}
```

## Custom Hooks Patterns

### Async Data Fetching Hook

```typescript
export function useQuery<T>(
  key: string,
  fetcher: () => Promise<T>,
  options?: { onSuccess?: (data: T) => void; onError?: (error: Error) => void; enabled?: boolean }
) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(false)

  const refetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await fetcher()
      setData(result)
      options?.onSuccess?.(result)
    } catch (err) {
      const error = err as Error
      setError(error)
      options?.onError?.(error)
    } finally {
      setLoading(false)
    }
  }, [fetcher, options])

  useEffect(() => {
    if (options?.enabled !== false) refetch()
  }, [key, refetch, options?.enabled])

  return { data, error, loading, refetch }
}
```

### Debounce Hook

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])
  return debouncedValue
}
```

## State Management: Context + Reducer

```typescript
type Action =
  | { type: 'SET_ITEMS'; payload: Item[] }
  | { type: 'SELECT_ITEM'; payload: Item }
  | { type: 'SET_LOADING'; payload: boolean }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_ITEMS': return { ...state, items: action.payload }
    case 'SELECT_ITEM': return { ...state, selectedItem: action.payload }
    case 'SET_LOADING': return { ...state, loading: action.payload }
    default: return state
  }
}
```

## Performance Optimization

### Memoization
- `useMemo` for expensive computations
- `useCallback` for functions passed to children
- `React.memo` for pure components

### Code Splitting & Lazy Loading
```typescript
const HeavyChart = lazy(() => import('./HeavyChart'))
<Suspense fallback={<ChartSkeleton />}><HeavyChart data={data} /></Suspense>
```

### Virtualization for Long Lists
Use `@tanstack/react-virtual` for lists with many items.

## Error Boundary Pattern

```typescript
export class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null }
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }
  render() {
    if (this.state.hasError) {
      return <div><h2>Something went wrong</h2><p>{this.state.error?.message}</p></div>
    }
    return this.props.children
  }
}
```

## Animation: Framer Motion

```typescript
<AnimatePresence>
  {items.map(item => (
    <motion.div
      key={item.id}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3 }}
    >
      <ItemCard item={item} />
    </motion.div>
  ))}
</AnimatePresence>
```

## Accessibility

- Semantic HTML first (button, nav, main, article)
- Keyboard navigation: ArrowDown/Up, Enter, Escape
- Focus management for modals (save/restore focus)
- ARIA attributes only when semantic HTML is insufficient

$ARGUMENTS
