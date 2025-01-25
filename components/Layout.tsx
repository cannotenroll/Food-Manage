import type React from "react"
import { BackButton } from "./BackButton"

interface LayoutProps {
  children: React.ReactNode
  title: string
}

export function Layout({ children, title }: LayoutProps) {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto p-4 max-w-4xl">
        <div className="mb-6">
          <BackButton />
          <h1 className="text-2xl font-bold mt-4">{title}</h1>
        </div>
        <div className="bg-white rounded-lg shadow-md p-6">{children}</div>
      </div>
    </div>
  )
}

