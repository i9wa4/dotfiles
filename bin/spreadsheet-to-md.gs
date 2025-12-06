/**
 * Export all sheets in the active spreadsheet as a single Markdown file.
 * Each sheet is converted to a CSV code block.
 *
 * Usage:
 *   Run this function from Google Apps Script editor.
 *
 * Output:
 *   - File saved to Google Drive root
 *   - Filename: {SpreadsheetName}_{YYYYMMDDHHMMSS}.md
 */
function exportAllSheetsAsMarkdown() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheets = ss.getSheets();
  let output = "";

  // Create timestamp (e.g., 20251017103725)
  const now = new Date();
  const pad = n => n.toString().padStart(2, "0");
  const timestamp = `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;

  // Export each sheet as Markdown + CSV block
  sheets.forEach(sheet => {
    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();

    if (lastRow === 0 || lastCol === 0) return; // Skip empty sheets

    output += `## ${sheet.getName()}\n\n\`\`\`csv\n`;

    const values = sheet.getRange(1, 1, lastRow, lastCol).getValues();
    values.forEach(row => {
      const csvRow = row.map(cell => {
        if (typeof cell === "string" && (cell.includes(",") || cell.includes("\"") || cell.includes("\n"))) {
          return `"${cell.replace(/"/g, '""')}"`;
        }
        return cell;
      }).join(",");
      output += csvRow + "\n";
    });

    output += "```\n\n";
  });

  // Filename: SpreadsheetName_YYYYMMDDHHMMSS.md
  const fileName = `${ss.getName()}_${timestamp}.md`;

  // Save to Google Drive root
  const file = DriveApp.createFile(fileName, output, MimeType.PLAIN_TEXT);

  // Show completion dialog
  SpreadsheetApp.getUi().alert(
    `Exported all sheets to Markdown!\n\nFile: ${fileName}\n\nURL:\n${file.getUrl()}`
  );
}
