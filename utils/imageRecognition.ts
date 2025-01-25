import type { FoodItem } from "../types/FoodItem"
import { mockFoods } from "./mockData"

export async function simulateImageRecognition(imageData: string): Promise<FoodItem> {
  console.log("Image captured or file selected, simulating AI recognition...")
  await new Promise((resolve) => setTimeout(resolve, 1000)) // Simulated API delay

  // Simulated recognition process
  return mockFoods[Math.floor(Math.random() * mockFoods.length)]
}

