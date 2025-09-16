const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const db = new sqlite3.Database("./lotto.db", (err) => {
  if (err) console.error("Failed to open DB:", err.message);
  else console.log("Connected to SQLite database.");
});

// ------------------- Utils -------------------
async function hashPassword(password) {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
}

// ------------------- Seed Admin -------------------
async function seedAdmin() {
  const adminEmail = "admin@example.com";
  const adminPassword = "admin123";

  db.get("SELECT * FROM customer WHERE email = ?", [adminEmail], async (err, row) => {
    if (err) return console.error(err);
    if (!row) {
      const hashedPassword = await hashPassword(adminPassword);
      db.run(
        "INSERT INTO customer (fullname, phone, email, password, wallet_balance, role) VALUES (?, ?, ?, ?, ?, ?)",
        ["Administrator", "0000000000", adminEmail, hashedPassword, 1000, "admin"]
      );
      console.log(`Admin account created: ${adminEmail} / ${adminPassword}`);
    } else {
      console.log("Admin account already exists");
    }
  });
}

// ------------------- Create Tables -------------------
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS customer (
      cus_id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullname TEXT,
      phone TEXT,
      email TEXT UNIQUE,
      password TEXT,
      wallet_balance REAL DEFAULT 0,
      role TEXT DEFAULT 'user'
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS lotto (
      lotto_id INTEGER PRIMARY KEY AUTOINCREMENT,
      number TEXT,
      round INTEGER,
      price REAL DEFAULT 80,
      status TEXT DEFAULT 'available'
    )
  `);
//ใช้เช็คทั้งขายหรือยัง ขึ้นเงินหรือยัง เเละlotto เป็นของใคร
  db.run(`
    CREATE TABLE IF NOT EXISTS purchase (
      purchase_id INTEGER PRIMARY KEY AUTOINCREMENT,
      cus_id INTEGER,
      lotto_id INTEGER,
      round INTEGER,
      purchase_date TEXT DEFAULT CURRENT_TIMESTAMP,
      is_redeemed INTEGER DEFAULT 0, 
      FOREIGN KEY (cus_id) REFERENCES customer(cus_id),   
      FOREIGN KEY (lotto_id) REFERENCES lotto(lotto_id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS prize (
      prize_id INTEGER PRIMARY KEY AUTOINCREMENT,
      round INTEGER,
      prize_type TEXT,
      number TEXT,
      reward_amount REAL
    )
  `, (err) => {
    if (!err) seedAdmin();
  });
});

// ------------------- Helper: Generate Lotto -------------------
function generateLotto(round, amount = 100) {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      db.run("DELETE FROM lotto WHERE round = ?", [round], (err) => {
        if (err) return reject(err);
        const stmt = db.prepare("INSERT INTO lotto (number, round, price, status) VALUES (?, ?, ?, ?)");
        let generated = new Set();
        while (generated.size < amount) {
          const num = String(Math.floor(Math.random() * 1000000)).padStart(6, "0");
          if (!generated.has(num)) {
            generated.add(num);
            stmt.run(num, round, 80, "available");
          }
        }
        stmt.finalize();
        resolve(Array.from(generated));
      });
    });
  });
}

// ------------------- Draw Prizes -------------------
function drawPrizes(round) {
  return new Promise((resolve, reject) => {
    db.get("SELECT COUNT(*) AS count FROM prize WHERE round = ?", [round], (err, row) => {
      if (err) return reject(err);
      if (row.count > 0) return reject("รางวัลของงวดนี้ออกแล้ว");

      db.all("SELECT number FROM lotto WHERE round = ?", [round], (err, lottoRows) => {
        if (err) return reject(err);
        if (lottoRows.length < 1) return reject("ยังไม่มีเลขสร้างเพียงพอสำหรับสุ่มรางวัล");

        const allNumbers = lottoRows.map(r => r.number);
        const shuffled = [...allNumbers].sort(() => 0.5 - Math.random());

        const firstPrize = shuffled[0]; // รางวัลที่ 1
        const secondPrize = shuffled[1] || shuffled[0]; // รางวัลที่ 2
        const thirdPrize = shuffled[2] || shuffled[0]; // รางวัลที่ 3

        // เลขท้าย 3 ตัว จะเอาจากรางวัลที่ 1
        const last3 = firstPrize.slice(-3);

        // เลขท้าย 2 ตัว ยังคงสุ่มจากเลขอื่น
        const randomNumFor2 = shuffled[3] || firstPrize;
        const last2 = randomNumFor2.slice(-2);

        const prizes = [
          { type: "รางวัลที่ 1", amount: 3000000, number: firstPrize },
          { type: "รางวัลที่ 2", amount: 200000, number: secondPrize },
          { type: "รางวัลที่ 3", amount: 80000, number: thirdPrize },
          { type: "เลขท้าย 3 ตัว", amount: 4000, number: last3 },
          { type: "เลขท้าย 2 ตัว", amount: 2000, number: last2 },
        ];

        const stmt = db.prepare("INSERT INTO prize (round, prize_type, number, reward_amount) VALUES (?, ?, ?, ?)");
        prizes.forEach(p => stmt.run(round, p.type, p.number, p.amount));
        stmt.finalize(() => resolve(prizes));
      });
    });
  });
}


// ------------------- API -------------------

// Register
app.post("/register", async (req, res) => {
  const { fullname, phone, email, password, wallet_balance } = req.body;
  if (!fullname || !phone || !email || !password)
    return res.status(400).json({ error: "กรุณากรอกข้อมูลให้ครบถ้วน" });

  try {
    const hashedPassword = await hashPassword(password);
    const role = "user";
    const balance = wallet_balance || 0;
    db.run(
      `INSERT INTO customer (fullname, phone, email, password, wallet_balance, role)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [fullname, phone, email, hashedPassword, balance, role],
      function (err) {
        if (err) return res.status(400).json({ error: err.message });
        res.status(201).json({
          message: "สมัครสมาชิกสำเร็จ",
          cus_id: this.lastID,
          fullname,
          phone,
          email,
          wallet_balance: balance,
          role,
        });
      }
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: "กรุณากรอก email และ password" });

  db.get("SELECT * FROM customer WHERE email = ?", [email], async (err, user) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!user) return res.status(401).json({ message: "ไม่พบบัญชีผู้ใช้นี้" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "รหัสผ่านไม่ถูกต้อง" });

    res.json({ message: "เข้าสู่ระบบสำเร็จ", user });
  });
});

// Current round
app.get("/current-round", (req, res) => {
  db.get("SELECT MAX(round) as maxRound FROM lotto", [], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    const nextRound = (row?.maxRound || 0) + 1;
    res.json({ round: nextRound });
  });
});

// Generate lotto
app.post("/generate", async (req, res) => {
  db.get("SELECT MAX(round) as maxRound FROM lotto", async (err, row) => {
    if (err) return res.status(500).json({ error: err.message });

    const round = (row?.maxRound || 0) + 1;

    if (round > 1) {
      const prevRound = round - 1;
      db.get("SELECT COUNT(*) as cnt FROM prize WHERE round = ?", [prevRound], async (err, r) => {
        if (err) return res.status(500).json({ error: err.message });
        if (prevRound > 0 && r.cnt === 0)
          return res.status(400).json({ message: "ยังไม่ออกรางวัลงวดก่อน" });

        const lotto_numbers = await generateLotto(round, 100);
        res.json({ message: `สร้าง Lotto งวด ${round} สำเร็จ`, lotto_numbers, round });
      });
    } else {
      const lotto_numbers = await generateLotto(round, 100);
      res.json({ message: `สร้าง Lotto งวด ${round} สำเร็จ`, lotto_numbers, round });
    }
  });
});

// Sold numbers
app.get("/sold-lotto/:round", (req, res) => {
  const round = req.params.round;
  db.all(
    "SELECT number FROM lotto WHERE round = ? AND status = 'sold'",
    [round],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      const sold_numbers = rows.map(r => r.number);
      res.json({ message: "ดึงเลขที่ขายแล้ว", sold_numbers });
    }
  );
});

// Prize info
app.get("/prize/:round", (req, res) => {
  const round = req.params.round;
  db.all("SELECT * FROM prize WHERE round = ?", [round], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    if (rows.length === 0) return res.json({ message: "ยังไม่ได้สุ่มรางวัล", prizes: [] });
    res.json({ message: "รางวัลงวดนี้", prizes: rows });
  });
});

// Draw prizes
app.post("/draw-prizes/:round", async (req, res) => {
  const round = req.params.round;
  try {
    const prizes = await drawPrizes(round);
    res.json({ message: "สุ่มรางวัลสำเร็จ", prizes });
  } catch (e) {
    res.status(400).json({ message: e });
  }
});

// Redeem (ขึ้นเงินรางวัล)
app.post("/redeem/:purchase_id", (req, res) => {
  const purchaseId = req.params.purchase_id;

  db.get(
    "SELECT is_redeemed, lotto_id, round FROM purchase WHERE purchase_id = ?",
    [purchaseId],
    (err, row) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!row) return res.status(404).json({ message: "ไม่พบการซื้อ" });
      if (row.is_redeemed) return res.status(400).json({ message: "คุณขึ้นเงินรางวัลแล้ว" });

      // เช็คว่าหมายเลขนี้ถูกรางวัลหรือไม่
      db.get(
        "SELECT * FROM prize WHERE round = ? AND number = (SELECT number FROM lotto WHERE lotto_id = ?)",
        [row.round, row.lotto_id],
        (err, prizeRow) => {
          if (err) return res.status(500).json({ error: err.message });
          if (!prizeRow) return res.status(400).json({ message: "เลขนี้ไม่ถูกรางวัล" });

          // อัปเดตเป็นขึ้นเงินแล้ว
          db.run(
            "UPDATE purchase SET is_redeemed = 1 WHERE purchase_id = ?",
            [purchaseId],
            (err) => {
              if (err) return res.status(500).json({ error: err.message });
              res.json({
                message: "ขึ้นเงินรางวัลสำเร็จ",
                prize: prizeRow,
              });
            }
          );
        }
      );
    }
  );
});

// Reset system
app.post("/reset-system", (req, res) => {
  db.serialize(() => {
    db.run("DELETE FROM lotto");
    db.run("DELETE FROM purchase");
    db.run("DELETE FROM prize");
    db.run("DELETE FROM customer WHERE role!='admin'", (err) => {
      if (err) return res.status(500).json({ error: err.message });

      db.run("DELETE FROM sqlite_sequence WHERE name='lotto'");
      db.run("DELETE FROM sqlite_sequence WHERE name='purchase'");
      db.run("DELETE FROM sqlite_sequence WHERE name='prize'");
      db.run("DELETE FROM sqlite_sequence WHERE name='customer' AND seq>0");

      res.json({ message: "รีเซ็ตระบบเรียบร้อยแล้ว ยกเว้น admin" });
    });
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
