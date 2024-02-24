// Import necessary modules
const request = require('supertest');
const express = require('express');
const { getTopCuisines } = require('../routes/UserInfo/UserFavorites');
const { openConnection, closeConnection } = require('../routes/DatabaseLogic');

// Assuming you need to mock external dependencies correctly
jest.mock('../routes/DatabaseLogic', () => ({
  openConnection: jest.fn().mockReturnValue({
    query: jest.fn().mockImplementation((query, params, callback) => callback(null, [
      { cuisine: 'italian_weight', weight: 80 },
      { cuisine: 'mexican_weight', weight: 70 },
      { cuisine: 'thai_weight', weight: 60 },
      { cuisine: 'japanese_weight', weight: 50 }
    ])),
    closeConnection: jest.fn(),
  }),
}));

// Setup Express app for endpoint testing
const app = express();
app.use(express.json());
const userInfoRouter = require('../routes/UserInfo/UserFavorite'); // Correct this path
app.use('/userInfo', userInfoRouter);

describe('getTopCuisines function and /top_cuisines/:user_id endpoint', () => {
  // Testing the function directly
  it('should return the top 4 cuisines based on user weights', async () => {
    const user_id = 72;
    const result = await getTopCuisines(user_id);

    expect(result).toEqual([
      { cuisine: 'italian_weight', weight: 80 },
      { cuisine: 'mexican_weight', weight: 70 },
      { cuisine: 'thai_weight', weight: 60 },
      { cuisine: 'japanese_weight', weight: 50 },
    ]);
  });

  // Testing the endpoint
  it('responds with top cuisines for a user', async () => {
    const userId = 72; // Example user ID
    const response = await request(app).get(`/userInfo/top_cuisines/${userId}`);

    expect(response.statusCode).toBe(200);
    // Note: Adjust the expected response as needed based on how your endpoint formats the response
    expect(response.body).toEqual(expect.arrayContaining(['Italian', 'Mexican', 'Thai', 'Japanese']));
  });
});
