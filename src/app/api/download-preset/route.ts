import { NextResponse } from 'next/server'
import AdmZip from 'adm-zip'
import { generateThemePreset } from '@/lib/theme-presets'

export async function GET() {
  try {
    const presetFiles = generateThemePreset()
    const zip = new AdmZip()
    
    for (const file of presetFiles) {
      zip.addFile(file.path, Buffer.from(file.content, 'utf8'))
    }
    
    const zipBuffer = zip.toBuffer()
    
    return new NextResponse(zipBuffer, {
      status: 200,
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': 'attachment; filename="theme-preset.zip"',
      }
    })
    
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to generate preset' 
    }, { status: 500 })
  }
}
