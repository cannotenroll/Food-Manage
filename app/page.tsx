import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
      <main className="bg-white rounded-lg shadow-md p-8 w-full max-w-md">
        <h1 className="text-3xl font-bold text-center mb-8">食材管理系统</h1>
        <nav className="space-y-4">
          <Link href="/inventory" className="block">
            <Button className="w-full justify-start text-lg" variant="outline">
              <span className="mr-2">📦</span> 库存管理
            </Button>
          </Link>
          <Link href="/purchase" className="block">
            <Button className="w-full justify-start text-lg" variant="outline">
              <span className="mr-2">🛒</span> 采购管理
            </Button>
          </Link>
          <Link href="/usage" className="block">
            <Button className="w-full justify-start text-lg" variant="outline">
              <span className="mr-2">🍽️</span> 领用管理
            </Button>
          </Link>
          <Link href="/reports" className="block">
            <Button className="w-full justify-start text-lg" variant="outline">
              <span className="mr-2">📊</span> 报表生成
            </Button>
          </Link>
        </nav>
      </main>
    </div>
  )
}

