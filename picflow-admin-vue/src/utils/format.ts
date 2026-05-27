export function formatTime(t: string): string {
  return t?.slice(0, 16).replace('T', ' ') || ''
}
