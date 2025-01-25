"use client"

import type React from "react"
import { useRef, useState } from "react"
import { Button } from "@/components/ui/button"
import { Camera } from "lucide-react"

interface CameraCaptureProps {
  onCapture: (imageData: string) => void
}

export const CameraCapture: React.FC<CameraCaptureProps> = ({ onCapture }) => {
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [isCapturing, setIsCapturing] = useState(false)

  const startCapture = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } })
      if (videoRef.current) {
        videoRef.current.srcObject = stream
        setIsCapturing(true)
      }
    } catch (err) {
      console.error("Error accessing camera:", err)
      alert("无法访问相机，请确保已授予相机权限。")
    }
  }

  const captureImage = () => {
    if (videoRef.current && canvasRef.current) {
      const context = canvasRef.current.getContext("2d")
      if (context) {
        context.drawImage(videoRef.current, 0, 0, canvasRef.current.width, canvasRef.current.height)
        const imageData = canvasRef.current.toDataURL("image/jpeg")
        onCapture(imageData)
        stopCapture()
      }
    }
  }

  const stopCapture = () => {
    if (videoRef.current && videoRef.current.srcObject) {
      const tracks = (videoRef.current.srcObject as MediaStream).getTracks()
      tracks.forEach((track) => track.stop())
      setIsCapturing(false)
    }
  }

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onloadend = () => {
        if (typeof reader.result === "string") {
          onCapture(reader.result)
        }
      }
      reader.readAsDataURL(file)
    }
  }

  return (
    <div className="relative w-full max-w-md mx-auto mb-4">
      {isCapturing ? (
        <>
          <video ref={videoRef} autoPlay playsInline className="w-full h-auto" />
          <Button onClick={captureImage} className="absolute bottom-4 left-1/2 transform -translate-x-1/2">
            <Camera className="mr-2 h-4 w-4" /> 拍照
          </Button>
        </>
      ) : (
        <div className="space-y-2">
          <Button onClick={startCapture} className="w-full">
            <Camera className="mr-2 h-4 w-4" /> 开始拍照
          </Button>
          <div className="text-center">或</div>
          <label className="block">
            <input
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              className="block w-full text-sm text-slate-500
                file:mr-4 file:py-2 file:px-4
                file:rounded-full file:border-0
                file:text-sm file:font-semibold
                file:bg-violet-50 file:text-violet-700
                hover:file:bg-violet-100"
            />
          </label>
        </div>
      )}
      <canvas ref={canvasRef} style={{ display: "none" }} width="640" height="480" />
    </div>
  )
}

