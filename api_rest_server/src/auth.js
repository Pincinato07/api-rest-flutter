import jwt from 'jsonwebtoken';

const SECRET = 'dev-secret-please-change';
export const jwtSecret = SECRET;

export function signToken(payload) {
  return jwt.sign(payload, SECRET, { expiresIn: '2h' });
}

export function authRequired(req, res, next) {
  const auth = req.headers.authorization || '';
  const [, token] = auth.split(' ');
  if (!token) return res.status(401).json({ message: 'Token ausente' });
  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded; // { id, role, email, name }
    next();
  } catch (e) {
    return res.status(401).json({ message: 'Token inválido/expirado' });
  }
}

export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ message: 'Não autenticado' });
    if (req.user.role !== role) return res.status(403).json({ message: 'Acesso negado' });
    next();
  };
}
