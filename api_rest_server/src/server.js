import express from 'express';
import morgan from 'morgan';
import cors from 'cors';
import { db } from './db.js';
import { signToken, authRequired, requireRole } from './auth.js';

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Health
app.get('/', (req, res) => res.json({ ok: true }));

// Auth
app.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  const user = db.users.find((u) => u.email === email && u.password === password);
  if (!user) return res.status(401).json({ message: 'Credenciais inválidas' });
  const token = signToken({ id: user.id, email: user.email, name: user.name, role: user.role });
  return res.json({ token });
});

// Me
app.get('/me', authRequired, (req, res) => {
  const user = db.users.find((u) => u.id === req.user.id);
  if (!user) return res.status(401).json({ message: 'Usuário não encontrado' });
  return res.json({ id: user.id, name: user.name, email: user.email, role: user.role });
});

// Admin-only users CRUD
app.get('/users', authRequired, requireRole('ADMIN'), (req, res) => {
  return res.json(db.users.map(({ password, ...u }) => u));
});

app.post('/users', authRequired, requireRole('ADMIN'), (req, res) => {
  const { name, email, password, role } = req.body || {};
  if (!name || !email || !password || !role) return res.status(400).json({ message: 'Campos obrigatórios' });
  const exists = db.users.some((u) => u.email === email);
  if (exists) return res.status(409).json({ message: 'E-mail já cadastrado' });
  const user = { id: db.nextUserId++, name, email, password, role };
  db.users.push(user);
  const { password: _p, ...safe } = user;
  return res.status(201).json(safe);
});

app.get('/users/:id', authRequired, requireRole('ADMIN'), (req, res) => {
  const id = Number(req.params.id);
  const user = db.users.find((u) => u.id === id);
  if (!user) return res.status(404).json({ message: 'Usuário não encontrado' });
  const { password, ...safe } = user;
  return res.json(safe);
});

app.put('/users/:id', authRequired, requireRole('ADMIN'), (req, res) => {
  const id = Number(req.params.id);
  const { name } = req.body || {};
  const user = db.users.find((u) => u.id === id);
  if (!user) return res.status(404).json({ message: 'Usuário não encontrado' });
  if (name) user.name = name;
  const { password, ...safe } = user;
  return res.json(safe);
});

app.delete('/users/:id', authRequired, requireRole('ADMIN'), (req, res) => {
  const id = Number(req.params.id);
  const idx = db.users.findIndex((u) => u.id === id);
  if (idx === -1) return res.status(404).json({ message: 'Usuário não encontrado' });
  db.users.splice(idx, 1);
  return res.status(204).send();
});

// Courses (public list, create requires auth)
app.get('/courses', (req, res) => {
  return res.json(db.courses.map((c) => ({ ...c })));
});

app.post('/courses', authRequired, (req, res) => {
  const { name, desc, price } = req.body || {};
  if (!name || !desc || price == null) return res.status(400).json({ message: 'Campos obrigatórios' });
  const course = { id: db.nextCourseId++, name, desc, price, ownerId: req.user.id };
  db.courses.push(course);
  return res.status(201).json(course);
});

app.put('/courses/:id', authRequired, (req, res) => {
  const id = Number(req.params.id);
  const c = db.courses.find((x) => x.id === id);
  if (!c) return res.status(404).json({ message: 'Curso não encontrado' });
  const isOwner = c.ownerId === req.user.id;
  const isAdmin = req.user.role === 'ADMIN';
  if (!isOwner && !isAdmin) return res.status(403).json({ message: 'Acesso negado' });
  const { name, desc, price } = req.body || {};
  if (name) c.name = name;
  if (desc) c.desc = desc;
  if (price != null) c.price = price;
  return res.json(c);
});

app.delete('/courses/:id', authRequired, (req, res) => {
  const id = Number(req.params.id);
  const idx = db.courses.findIndex((x) => x.id === id);
  if (idx === -1) return res.status(404).json({ message: 'Curso não encontrado' });
  const c = db.courses[idx];
  const isOwner = c.ownerId === req.user.id;
  const isAdmin = req.user.role === 'ADMIN';
  if (!isOwner && !isAdmin) return res.status(403).json({ message: 'Acesso negado' });
  db.courses.splice(idx, 1);
  return res.status(204).send();
});

// Admin protected sample route
app.get('/admin', authRequired, requireRole('ADMIN'), (req, res) => {
  res.json({ message: 'Área admin' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API rodando em http://localhost:${PORT}`));
