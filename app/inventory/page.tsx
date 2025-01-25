"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { CameraCapture } from "@/components/CameraCapture"
import { FoodList } from "@/components/FoodList"
import { SearchBar } from "@/components/SearchBar"
import { Layout } from "@/components/Layout"
import { Camera } from "lucide-react"
import type { FoodItem } from "@/types/FoodItem"
import { mockFoods, mockFrequentFoods } from "@/utils/mockData"
import { simulateImageRecognition } from "@/utils/imageRecognition"

export default function InventoryPage() {
  const [foods, setFoods] = useState<FoodItem[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [showCamera, setShowCamera] = useState(false)

  useEffect(() => {
    setFoods(mockFoods)
  }, [])

  const handleCapture = async (imageData: string) => {
    const recognizedFood = await simulateImageRecognition(imageData)
    setSearchTerm(recognizedFood.name)
    setShowCamera(false)
    alert(`识别结果：${recognizedFood.name}`)
  }

  const handleQuickAdd = (food: FoodItem) => {
    console.log(`快速添加 ${food.name}`)
    alert(`已添加 ${food.name}`)
  }

  return (
    <Layout title="库存管理">
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <SearchBar searchTerm={searchTerm} setSearchTerm={setSearchTerm} className="flex-grow" />
        <Button onClick={() => setShowCamera(true)} className="whitespace-nowrap">
          <Camera className="mr-2 h-4 w-4" /> 拍照识别
        </Button>
      </div>
      {showCamera && <CameraCapture onCapture={handleCapture} className="mb-6" />}
      <FoodList foods={foods} searchTerm={searchTerm} onQuickAdd={handleQuickAdd} frequentFoods={mockFrequentFoods} />
    </Layout>
  )
}

