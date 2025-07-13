import { NextRequest, NextResponse } from 'next/server'
import { writeFile } from 'fs/promises'
import path from 'path'
import { Theme } from '@/types'
import { addTheme, ensureThemesDirectory } from '@/lib/file-storage'

export async function POST(request: NextRequest) {
  try {
    await ensureThemesDirectory()

    const formData = await request.formData()
    const file = formData.get('themeFile') as File
    const themeName = formData.get('themeName') as string
    const themeVersion = formData.get('themeVersion') as string
    const developerName = formData.get('developerName') as string
    const description = formData.get('description') as string

    if (!file || !themeName || !themeVersion || !developerName || !description) {
      return NextResponse.json({ 
        success: false, 
        error: 'All fields are required' 
      }, { status: 400 })
    }

    const themeId = Date.now().toString()
    const fileExtension = path.extname(file.name)
    const filename = `theme_${themeId}${fileExtension}`
    const filePath = path.join('./themes', filename)

    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filePath, buffer)

    const theme: Theme = {
      id: themeId,
      name: themeName,
      version: themeVersion,
      developer: developerName,
      description,
      filename,
      uploadDate: new Date().toISOString(),
      fileSize: file.size
    }

    await addTheme(theme)

    return NextResponse.json({
      success: true,
      message: 'Theme uploaded successfully',
      themeId
    })

  } catch (error) {
    console.error('Upload error:', error)
    return NextResponse.json({ 
      success: false, 
      error: 'Upload failed' 
    }, { status: 500 })
  }
}
