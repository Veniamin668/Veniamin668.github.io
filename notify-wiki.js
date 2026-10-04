const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const BOT_TOKEN = process.env.TELEGRAM_TOKEN;
const CHAT_ID = process.env.TELEGRAM_CHAT_ID;
const WIKI_URL = process.env.WIKI_URL || 'https://veniamin668.github.io/wiki';

if (!BOT_TOKEN || !CHAT_ID) {
  console.log('⚠ TELEGRAM_TOKEN или TELEGRAM_CHAT_ID не настроены в Secrets. Пропускаем отправку.');
  process.exit(0);
}

// 1. Общее количество заметок
const wikiDir = path.join(__dirname, 'wiki');
let totalNotes = 0;
if (fs.existsSync(wikiDir)) {
  totalNotes = fs.readdirSync(wikiDir).filter(f => f.endsWith('.md')).length;
}

// 2. Отслеживаем изменения в папке wiki/ за последний коммит
let gitChanges = '';
try {
  gitChanges = execSync('git diff --name-status HEAD~1 HEAD -- wiki/', { encoding: 'utf8' }).trim();
} catch (e) {
  gitChanges = '';
}

const added = [];
const modified = [];
const deleted = [];

if (gitChanges) {
  gitChanges.split('\n').forEach(line => {
    const parts = line.split(/\s+/);
    const status = parts[0];
    const filePath = parts[1];
    if (!filePath) return;
    
    const fileName = path.basename(filePath);
    if (status.startsWith('A')) added.push(fileName);
    else if (status.startsWith('M')) modified.push(fileName);
    else if (status.startsWith('D')) deleted.push(fileName);
  });
}

// 3. Достаем последние 3 коммита
let recentCommits = '';
try {
  recentCommits = execSync('git log -n 3 --pretty=format:"• %s (<code>%h</code>)"', { encoding: 'utf8' }).trim();
} catch (e) {
  recentCommits = '• Не удалось получить историю коммитов';
}

// 4. Формируем красивый HTML-текст сообщения
let message = `<b>🧠 Obsidian Wiki Обновлена!</b>\n\n`;

message += `📊 <b>Статистика базы:</b>\n`;
message += `• Всего заметок: <b>${totalNotes}</b>\n`;

if (added.length > 0) {
  message += `• ✨ Новые заметки (${added.length}): ${added.map(f => `<code>${f}</code>`).join(', ')}\n`;
}
if (modified.length > 0) {
  message += `• 📝 Обновлены (${modified.length}): ${modified.map(f => `<code>${f}</code>`).join(', ')}\n`;
}
if (deleted.length > 0) {
  message += `• 🗑 Удалены (${deleted.length}): ${deleted.map(f => `<code>${f}</code>`).join(', ')}\n`;
}
if (added.length === 0 && modified.length === 0 && deleted.length === 0) {
  message += `• Прямых правок в .md файлах не было (пересборка/правка кода)\n`;
}

message += `\n📜 <b>Свежие коммиты:</b>\n${recentCommits}\n\n`;
message += `🌐 <a href="${WIKI_URL}">Перейти в Wiki</a>`;

// 5. Отправка через Telegram Bot API
async function sendNotification() {
  try {
    const res = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: CHAT_ID,
        text: message,
        parse_mode: 'HTML',
        disable_web_page_preview: false
      })
    });

    const data = await res.json();
    if (data.ok) {
      console.log('🚀 Пуш-уведомление успешно отправлено в Telegram!');
    } else {
      console.error('❌ Ошибка отправки Telegram:', data);
    }
  } catch (err) {
    console.error('❌ Сбой сети при отправке в Telegram:', err);
  }
}

sendNotification();
