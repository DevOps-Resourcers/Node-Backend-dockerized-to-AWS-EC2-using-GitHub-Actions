# ----------- Stage 1: Build Stage -----------
    FROM node:20.9.0 AS builder

    # Set working directory
    WORKDIR /app
    
    # Copy package.json and package-lock.json
    COPY package*.json ./
    
    # Install dependencies
    RUN npm install
    
    # Copy the rest of the application code
    COPY . .
    
    
    # ----------- Stage 2: Production Stage -----------
    FROM node:20.9.0-slim
    
    # Set working directory
    WORKDIR /app
    
    # Copy built app and node_modules from builder stage
    COPY --from=builder /app /app
    
    # Install only production dependencies
    RUN npm install --omit=dev
    
    # Expose the application port
    EXPOSE 4000
    
    # Start the application
    CMD ["npm", "start"]
    