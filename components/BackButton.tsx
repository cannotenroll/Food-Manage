import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"

export function BackButton() {
  return (
    <Link href="/">
      <Button variant="outline" className="mb-4">
        <ArrowLeft className="mr-2 h-4 w-4" /> 返回主页
      </Button>
    </Link>
  )
}

