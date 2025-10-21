function exportAllSheetsAsMarkdown() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheets = ss.getSheets();
  let output = "";

  // タイムスタンプを作成（例: 20251017103725）
  const now = new Date();
  const pad = n => n.toString().padStart(2, "0");
  const timestamp = `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;

  // 各シートをMarkdown + CSVブロックとして出力
  sheets.forEach(sheet => {
    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();

    if (lastRow === 0 || lastCol === 0) return; // 空シートスキップ

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

  // ファイル名: スプレッドシート名_YYYYMMDDHHMMSS.md
  const fileName = `${ss.getName()}_${timestamp}.md`;

  // マイドライブ直下に保存
  const file = DriveApp.createFile(fileName, output, MimeType.PLAIN_TEXT);

  // 完了通知
  SpreadsheetApp.getUi().alert(
    `全シートをMarkdown形式で出力しました！\n\nファイル: ${fileName}\n\nURL:\n${file.getUrl()}`
  );
}
