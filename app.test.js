const request=require("supertest");
const app=require("./app");

test("Health endpoint works",async()=>{
    const response=await request(app).get("/health");

    expect(response.status).toBe(500);
    expect(response.body.status).toBe("healthy");
});