"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { CameraCapture } from "@/components/CameraCapture"
import { Layout } from "@/components/Layout"
import { Camera } from "lucide-react"
import type { FoodItem } from "@/types/FoodItem"
import { simulateImageRecognition } from "@/utils/imageRecognition"

export default function PurchasePage() {
  const [showCamera, setShowCamera] = useState(false)
  const [newFood, setNewFood] = useState<Partial<FoodItem>>({
    name: "",
    category: "",
    quantity: 0,
    unit: "",
    averagePrice: 0,
  })
  const [totalAmount, setTotalAmount] = useState(0)
  const [existingFood, setExistingFood] = useState<FoodItem | null>(null)

  useEffect(() => {
    const quantity = newFood.quantity || 0
    const price = newFood.averagePrice || 0
    setTotalAmount(quantity * price)
  }, [newFood.quantity, newFood.averagePrice])

  const handleCapture = async (imageData: string) => {
    const recognizedFood = await simulateImageRecognition(imageData)
    setNewFood((prev) => ({ ...prev, name: recognizedFood.name }))
    setShowCamera(false)
    alert(`识别结果：${recognizedFood.name}`)

    // 模拟从数据库获取现有食材信息
    const mockExistingFood: FoodItem = {
      ...recognizedFood,
      quantity: 50,
    }
    setExistingFood(mockExistingFood)
  }

  const calculateNewAveragePrice = (existingFood: FoodItem, newQuantity: number, newPrice: number) => {
    const totalExistingValue = existingFood.quantity * existingFood.averagePrice
    const totalNewValue = newQuantity * newPrice
    const totalNewQuantity = existingFood.quantity + newQuantity
    return (totalExistingValue + totalNewValue) / totalNewQuantity
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (existingFood) {
      const newAveragePrice = calculateNewAveragePrice(existingFood, newFood.quantity || 0, newFood.averagePrice || 0)
      console.log("更新后的加权平均价格:", newAveragePrice)
    }
    console.log("提交采购信息:", newFood)
    console.log("总金额:", totalAmount)
    // 这里你会调用API来保存采购信息和更新库存
    alert(`采购信息已提交，总金额：${totalAmount.toFixed(2)} 元`)
    setNewFood({
      name: "",
      category: "",
      quantity: 0,
      unit: "",
      averagePrice: 0,
    })
    setExistingFood(null)
  }

  return (
    <Layout title="采购管理">
      <div className="flex justify-between mb-6">
        <Button onClick={() => setShowCamera(true)}>
          <Camera className="mr-2 h-4 w-4" /> 拍照识别
        </Button>
        <Button type="submit" form="purchaseForm">
          提交采购信息
        </Button>
      </div>
      {showCamera && <CameraCapture onCapture={handleCapture} className="mb-6" />}
      <form id="purchaseForm" onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <Label htmlFor="name">食材名称</Label>
            <Input
              id="name"
              value={newFood.name || ""}
              onChange={(e) => setNewFood((prev) => ({ ...prev, name: e.target.value }))}
              required
            />
          </div>
          <div>
            <Label htmlFor="category">类别</Label>
            <Input
              id="category"
              value={newFood.category || ""}
              onChange={(e) => setNewFood((prev) => ({ ...prev, category: e.target.value }))}
              required
            />
          </div>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div>
            <Label htmlFor="quantity">数量</Label>
            <Input
              id="quantity"
              type="number"
              value={newFood.quantity || ""}
              onChange={(e) => setNewFood((prev) => ({ ...prev, quantity: Number(e.target.value) }))}
              required
            />
          </div>
          <div>
            <Label htmlFor="unit">单位</Label>
            <Input
              id="unit"
              value={newFood.unit || ""}
              onChange={(e) => setNewFood((prev) => ({ ...prev, unit: e.target.value }))}
              required
            />
          </div>
          <div>
            <Label htmlFor="price">单价（元）</Label>
            <Input
              id="price"
              type="number"
              step="0.01"
              value={newFood.averagePrice || ""}
              onChange={(e) => setNewFood((prev) => ({ ...prev, averagePrice: Number(e.target.value) }))}
              required
            />
          </div>
        </div>
        <div>
          <Label>总金额（元）</Label>
          <Input type="number" value={totalAmount.toFixed(2)} readOnly className="bg-gray-100 font-bold" />
        </div>
        {existingFood && (
          <div className="mt-4 p-4 bg-blue-50 rounded">
            <h3 className="font-semibold mb-2">现有库存信息</h3>
            <p>
              当前库存: {existingFood.quantity} {existingFood.unit}
            </p>
            <p>
              当前平均价格: {existingFood.averagePrice.toFixed(2)} 元/{existingFood.unit}
            </p>
          </div>
        )}
      </form>
    </Layout>
  )
}

