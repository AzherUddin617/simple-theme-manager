import { NextResponse } from 'next/server'
import { loadThemes } from '@/lib/file-storage'

export async function GET() {
  try {
    const themes = await loadThemes()
    return NextResponse.json({ success: true, themes })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to load themes' 
    }, { status: 500 })
  }
}
