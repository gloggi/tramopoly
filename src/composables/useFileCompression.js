import Compressor from 'compressorjs'

export default function useFileCompression() {
  async function getCompressedImage(file) {
    if (!file.type?.startsWith('image/') && !['jpg', 'png', 'jpeg'].includes(file.type?.toLowerCase())) {
      return file
    }
    return new Promise((resolve, reject) => {
      new Compressor(file.blob || file, {
        retainExif: true,
        checkOrientation: true,
        maxWidth: 1024,
        maxHeight: 1024,
        success(result) {
          resolve(result)
        },
        error(err) {
          console.log(err.message)
          reject(err)
        },
      })
    })
  }

  async function getCompressedImageUrl(file) {
    const compressed = await getCompressedImage(file)
    return compressed.url || compressed.localUrl || URL.createObjectURL(compressed)
  }

  return { getCompressedImage, getCompressedImageUrl }
}
