"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Layout } from "@/components/Layout"

export default function ReportsPage() {
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")

  const handleGenerateReport = () => {
    console.log(`生成从 ${startDate} 到 ${endDate} 的报表`)
    // Here you would call an API to generate the report
    alert(`报表已生成，时间范围：${startDate} 到 ${endDate}`)
  }

  return (
    <Layout title="报表生成">
      <div className="space-y-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <Label htmlFor="startDate">开始日期</Label>
            <Input
              id="startDate"
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="w-full"
            />
          </div>
          <div>
            <Label htmlFor="endDate">结束日期</Label>
            <Input
              id="endDate"
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="w-full"
            />
          </div>
        </div>
        <Button onClick={handleGenerateReport} className="w-full">
          生成报表
        </Button>
      </div>
    </Layout>
  )
}

