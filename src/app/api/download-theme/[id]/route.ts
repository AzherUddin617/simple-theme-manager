import { NextRequest, NextResponse } from 'next/server'
import { readFile } from 'fs/promises'
import path from 'path'
import { getThemeById } from '@/lib/file-storage'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const theme = await getThemeById(params.id)
    
    if (!theme) {
      return NextResponse.json({ 
        success: false, 
        error: 'Theme not found' 
      }, { status: 404 })
    }

    const filePath = path.join('./themes', theme.filename)
    const fileBuffer = await readFile(filePath)

    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': `attachment; filename="${theme.filename}"`,
      }
    })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Download failed' 
    }, { status: 500 })
  }
}
