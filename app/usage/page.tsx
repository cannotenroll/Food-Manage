"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { CameraCapture } from "@/components/CameraCapture"
import { FoodList } from "@/components/FoodList"
import { SearchBar } from "@/components/SearchBar"
import { Layout } from "@/components/Layout"
import { Camera } from "lucide-react"
import type { FoodItem } from "@/types/FoodItem"
import { mockFoods } from "@/utils/mockData"
import { simulateImageRecognition } from "@/utils/imageRecognition"

export default function UsagePage() {
  const [foods, setFoods] = useState<FoodItem[]>([])
  const [selectedFood, setSelectedFood] = useState<FoodItem | null>(null)
  const [usageQuantity, setUsageQuantity] = useState<number>(0)
  const [showCamera, setShowCamera] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")

  useEffect(() => {
    setFoods(mockFoods)
  }, [])

  const handleCapture = async (imageData: string) => {
    const recognizedFood = await simulateImageRecognition(imageData)
    setSelectedFood(recognizedFood)
    setShowCamera(false)
    alert(`识别结果：${recognizedFood.name}`)
  }

  const handleUsage = () => {
    if (selectedFood && usageQuantity > 0) {
      const totalAmount = selectedFood.averagePrice * usageQuantity
      console.log(
        `领用 ${usageQuantity} ${selectedFood.unit} 的 ${selectedFood.name}，总金额：${totalAmount.toFixed(2)} 元`,
      )
      alert(
        `已领用 ${usageQuantity} ${selectedFood.unit} 的 ${selectedFood.name}，总金额：${totalAmount.toFixed(2)} 元`,
      )
      setSelectedFood(null)
      setUsageQuantity(0)
    }
  }

  return (
    <Layout title="领用管理">
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <SearchBar searchTerm={searchTerm} setSearchTerm={setSearchTerm} className="flex-grow" />
        <Button onClick={() => setShowCamera(true)} className="whitespace-nowrap">
          <Camera className="mr-2 h-4 w-4" /> 拍照识别
        </Button>
      </div>
      {showCamera && <CameraCapture onCapture={handleCapture} className="mb-6" />}
      {selectedFood && (
        <div className="mb-6 p-4 border rounded bg-white shadow">
          <h2 className="text-xl font-semibold mb-2">{selectedFood.name}</h2>
          <p>
            当前库存: {selectedFood.quantity} {selectedFood.unit}
          </p>
          <p>
            单价: {selectedFood.averagePrice.toFixed(2)} 元/{selectedFood.unit}
          </p>
          <div className="mt-4 flex items-end gap-4">
            <div className="flex-grow">
              <Label htmlFor="usageQuantity">领用数量</Label>
              <Input
                id="usageQuantity"
                type="number"
                value={usageQuantity}
                onChange={(e) => setUsageQuantity(Number(e.target.value))}
                min="0"
                max={selectedFood.quantity}
              />
            </div>
            <Button onClick={handleUsage}>确认领用</Button>
          </div>
          <p className="mt-2 font-bold">总金额: {(selectedFood.averagePrice * usageQuantity).toFixed(2)} 元</p>
        </div>
      )}
      <FoodList foods={foods} searchTerm={searchTerm} />
    </Layout>
  )
}

