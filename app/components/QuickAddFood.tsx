import type React from "react"
import type { FoodItem } from "../types/FoodItem"
import { Button } from "@/components/ui/button"

interface QuickAddFoodProps {
  frequentFoods: FoodItem[]
  onQuickAdd: (food: FoodItem) => void
}

export const QuickAddFood: React.FC<QuickAddFoodProps> = ({ frequentFoods, onQuickAdd }) => {
  return (
    <div className="mt-4">
      <h2 className="text-lg font-semibold mb-2">快速添加常用食�?/h2>
      <div className="flex flex-wrap gap-2">
        {frequentFoods.map((food) => (
          <Button key={food.id} onClick={() => onQuickAdd(food)} variant="outline" size="sm">
            {food.name}
          </Button>
        ))}
      </div>
    </div>
  )
}

