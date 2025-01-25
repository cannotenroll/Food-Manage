import type { FoodItem } from "@/types/FoodItem"
import { Button } from "@/components/ui/button"

interface FoodListProps {
  foods: FoodItem[]
  searchTerm: string
  onQuickAdd?: (food: FoodItem) => void
  frequentFoods?: FoodItem[]
}

export const FoodList: React.FC<FoodListProps> = ({ foods, searchTerm, onQuickAdd, frequentFoods }) => {
  const filteredFoods = foods.filter((food) => food.name.toLowerCase().includes(searchTerm.toLowerCase()))

  return (
    <div>
      {frequentFoods && onQuickAdd && (
        <div className="mt-4 mb-6">
          <h2 className="text-lg font-semibold mb-2">快速添加常用食材</h2>
          <div className="flex flex-wrap gap-2">
            {frequentFoods.map((food) => (
              <Button key={food.id} onClick={() => onQuickAdd(food)} variant="outline" size="sm">
                {food.name}
              </Button>
            ))}
          </div>
        </div>
      )}
      <ul className="space-y-2 mt-4">
        {filteredFoods.map((food) => (
          <li key={food.id} className="bg-white p-4 rounded shadow">
            <h3 className="text-lg font-semibold">{food.name}</h3>
            <p>类别: {food.category}</p>
            <p>
              数量: {food.quantity} {food.unit}
            </p>
            <p>
              平均单价: {food.averagePrice.toFixed(2)} 元/{food.unit}
            </p>
          </li>
        ))}
      </ul>
    </div>
  )
}

