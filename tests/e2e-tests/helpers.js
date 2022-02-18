export function genHeader(contentType) {
  return {
    "Content-Type": `${contentType}`,
  };
}
