import express from 'express'
import type {Request, Response} from 'express'
const app= express();
const PORT=9000

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req:Request, res: Response) => {
    res.json({ message: 'Server is running!' });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});