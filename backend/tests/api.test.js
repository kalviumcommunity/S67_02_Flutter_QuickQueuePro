const request = require('supertest');
const app     = require('../server');

describe('Auth Endpoints', () => {
  it('POST /api/auth/register - rejects missing fields', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ email: 'test@test.com' });
    expect(res.statusCode).toBe(422);
    expect(res.body).toHaveProperty('errors');
  });

  it('POST /api/auth/login - rejects invalid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'nobody@nowhere.com', password: 'wrongpass' });
    expect(res.statusCode).toBe(401);
  });
});

describe('Queue Endpoints', () => {
  it('POST /api/queues/join - rejects unauthenticated request', async () => {
    const res = await request(app)
      .post('/api/queues/join')
      .send({ vendor_id: 1 });
    expect(res.statusCode).toBe(401);
  });

  it('GET /api/queues/my - rejects unauthenticated request', async () => {
    const res = await request(app).get('/api/queues/my');
    expect(res.statusCode).toBe(401);
  });
});
