// In-memory DB for demo purposes
export const db = {
  users: [
    {
      id: 1,
      name: 'Admin',
      email: 'admin@email.com',
      password: 'admin123', // DO NOT use plain text in production.
      role: 'ADMIN',
    },
  ],
  courses: [
    // { id: 1, name: 'Curso', desc: '...', price: 100, ownerId: 1 }
  ],
  nextUserId: 2,
  nextCourseId: 1,
};
