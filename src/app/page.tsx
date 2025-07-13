"use client";

import { Theme } from "@/types";
import { Calendar, Download, Package, Upload, User } from "lucide-react";
import React, { useEffect, useState } from "react";

export default function AdminPage() {
	const [themes, setThemes] = useState<Theme[]>([]);
	const [loading, setLoading] = useState(true);
	const [uploading, setUploading] = useState(false);
	const [downloadingPreset, setDownloadingPreset] = useState(false);

	const [formData, setFormData] = useState({
		themeName: "",
		themeVersion: "",
		developerName: "",
		description: "",
	});
	const [file, setFile] = useState<File | null>(null);
	const [uploadResult, setUploadResult] = useState<string | null>(null);

	useEffect(() => {
		fetchThemes();
	}, []);

	const fetchThemes = async () => {
		try {
			const response = await fetch("/api/themes");
			const result = await response.json();
			if (result.success) {
				setThemes(result.themes);
			}
		} catch (error) {
			console.error("Failed to fetch themes:", error);
		} finally {
			setLoading(false);
		}
	};

	const handleInputChange = (
		e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
	) => {
		const { name, value } = e.target;
		setFormData((prev) => ({ ...prev, [name]: value }));
	};

	const handleFileSelect = (selectedFile: File) => {
		if (selectedFile && selectedFile.name.endsWith(".zip")) {
			setFile(selectedFile);
			setUploadResult(null);
		} else {
			alert("Please select a ZIP file");
		}
	};

	const handleUpload = async () => {
		if (
			!file ||
			!formData.themeName ||
			!formData.themeVersion ||
			!formData.developerName ||
			!formData.description
		) {
			alert("Please fill all fields and select a file");
			return;
		}

		setUploading(true);
		setUploadResult(null);

		try {
			const submitData = new FormData();
			submitData.append("themeFile", file);
			submitData.append("themeName", formData.themeName);
			submitData.append("themeVersion", formData.themeVersion);
			submitData.append("developerName", formData.developerName);
			submitData.append("description", formData.description);

			const response = await fetch("/api/upload-theme", {
				method: "POST",
				body: submitData,
			});

			const result = await response.json();

			if (result.success) {
				setUploadResult("✅ Theme uploaded successfully!");
				setFormData({
					themeName: "",
					themeVersion: "",
					developerName: "",
					description: "",
				});
				setFile(null);
				fetchThemes();
			} else {
				setUploadResult(`❌ Upload failed: ${result.error}`);
			}
		} catch (error) {
			setUploadResult("❌ Network error. Please try again.");
		} finally {
			setUploading(false);
		}
	};

	const downloadPreset = async () => {
		setDownloadingPreset(true);
		try {
			const response = await fetch("/api/download-preset");
			const blob = await response.blob();

			const url = window.URL.createObjectURL(blob);
			const a = document.createElement("a");
			a.href = url;
			a.download = "theme-preset.zip";
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		} catch (error) {
			alert("Download failed");
		} finally {
			setDownloadingPreset(false);
		}
	};

	const downloadTheme = async (themeId: string, filename: string) => {
		try {
			const response = await fetch(`/api/download-theme/${themeId}`);
			const blob = await response.blob();

			const url = window.URL.createObjectURL(blob);
			const a = document.createElement("a");
			a.href = url;
			a.download = filename;
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		} catch (error) {
			alert("Download failed");
		}
	};

	return (
		<div className="min-h-screen bg-gray-50">
			<div className="bg-white shadow-sm border-b">
				<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
					<h1 className="text-3xl font-bold text-gray-900">
						Simple Theme Manager
					</h1>
					<p className="mt-1 text-sm text-gray-500">
						Upload and manage themes locally
					</p>
				</div>
			</div>

			<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
				<div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
					{/* Upload Section */}
					<div className="bg-white rounded-lg shadow-md p-6">
						<div className="flex items-center justify-between mb-6">
							<h2 className="text-xl font-semibold text-gray-900">
								Upload Theme
							</h2>
							<button
								onClick={downloadPreset}
								disabled={downloadingPreset}
								className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50">
								{downloadingPreset ? (
									<div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
								) : (
									<Download className="w-4 h-4 mr-2" />
								)}
								Download Preset
							</button>
						</div>

						<div className="space-y-4">
							<div>
								<label className="block text-sm font-medium text-gray-700 mb-1">
									Theme Name
								</label>
								<input
									type="text"
									name="themeName"
									value={formData.themeName}
									onChange={handleInputChange}
									placeholder="e.g., Modern Store Theme"
									className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-1">
									Version
								</label>
								<input
									type="text"
									name="themeVersion"
									value={formData.themeVersion}
									onChange={handleInputChange}
									placeholder="e.g., 1.0.0"
									className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-1">
									Developer Name
								</label>
								<input
									type="text"
									name="developerName"
									value={formData.developerName}
									onChange={handleInputChange}
									placeholder="Your name or company"
									className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-1">
									Description
								</label>
								<textarea
									name="description"
									value={formData.description}
									onChange={handleInputChange}
									rows={3}
									placeholder="Describe your theme..."
									className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-1">
									Theme File (ZIP)
								</label>
								<div className="relative border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
									{file ? (
										<div>
											<Package className="w-8 h-8 mx-auto text-green-600 mb-2" />
											<p className="text-sm font-medium text-green-600">
												{file.name}
											</p>
											<p className="text-xs text-gray-500">
												{(
													file.size /
													(1024 * 1024)
												).toFixed(2)}{" "}
												MB
											</p>
											<button
												onClick={() => setFile(null)}
												className="mt-2 text-sm text-red-600 hover:text-red-800">
												Remove
											</button>
										</div>
									) : (
										<div>
											<Upload className="w-8 h-8 mx-auto text-gray-400 mb-2" />
											<p className="text-sm text-gray-600">
												Choose ZIP file
											</p>
											<input
												type="file"
												accept=".zip"
												onChange={(e) =>
													e.target.files &&
													handleFileSelect(
														e.target.files[0]
													)
												}
												className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
											/>
										</div>
									)}
								</div>
							</div>

							{uploadResult && (
								<div
									className={`p-3 rounded-lg ${
										uploadResult.includes("✅")
											? "bg-green-50 text-green-800"
											: "bg-red-50 text-red-800"
									}`}>
									{uploadResult}
								</div>
							)}

							<button
								onClick={handleUpload}
								disabled={uploading}
								className="w-full py-3 px-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 font-medium">
								{uploading ? (
									<div className="flex items-center justify-center">
										<div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
										Uploading...
									</div>
								) : (
									"Upload Theme"
								)}
							</button>
						</div>
					</div>

					{/* Themes List */}
					<div className="bg-white rounded-lg shadow-md p-6">
						<h2 className="text-xl font-semibold text-gray-900 mb-6">
							Uploaded Themes ({themes.length})
						</h2>

						{loading ? (
							<div className="text-center py-8">
								<div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
								<p className="mt-2 text-gray-500">
									Loading themes...
								</p>
							</div>
						) : themes.length === 0 ? (
							<div className="text-center py-8">
								<Package className="w-12 h-12 mx-auto text-gray-400 mb-4" />
								<p className="text-gray-500">
									No themes uploaded yet
								</p>
							</div>
						) : (
							<div className="space-y-4">
								{themes.map((theme) => (
									<div
										key={theme.id}
										className="border border-gray-200 rounded-lg p-4">
										<div className="flex items-start justify-between">
											<div className="flex-1">
												<h3 className="font-semibold text-gray-900">
													{theme.name}
												</h3>
												<p className="text-sm text-gray-600 mt-1">
													{theme.description}
												</p>
												<div className="flex items-center space-x-4 mt-2 text-xs text-gray-500">
													<div className="flex items-center">
														<User className="w-3 h-3 mr-1" />
														{theme.developer}
													</div>
													<div className="flex items-center">
														<Package className="w-3 h-3 mr-1" />
														v{theme.version}
													</div>
													<div className="flex items-center">
														<Calendar className="w-3 h-3 mr-1" />
														{new Date(
															theme.uploadDate
														).toLocaleDateString()}
													</div>
												</div>
											</div>
											<button
												onClick={() =>
													downloadTheme(
														theme.id,
														theme.filename
													)
												}
												className="ml-4 inline-flex items-center px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700">
												<Download className="w-3 h-3 mr-1" />
												Download
											</button>
										</div>
									</div>
								))}
							</div>
						)}
					</div>
				</div>
			</div>
		</div>
	);
}
