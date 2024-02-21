# Documentation

## Introduction

Welcome! This guide will help you understand how to interact with the cart controllers for levels 1, 2, and 3. It provides information on the input required for each controller and the corresponding output.

## Controller Overview

Our application consists of three levels of cart controllers:

1. **Level 1**: Basic cart functionality.
2. **Level 2**: Enhanced cart functionality with delivery fee calculation.
3. **Level 3**: Advanced cart functionality with discounts and delivery fee calculation.

## Controller Endpoints

### Level 1 Controller

#### Endpoint:

POST /level1/carts/checkout

#### Input:
- **articles**: Array of article objects containing `id`, `name`, and `price`.
- **carts**: Array of cart objects containing `id` and `items`, where each item includes `article_id` and `quantity`.
- Payload format: JSON data

#### Output:
- Returns a JSON object with the `carts` key containing an array of carts with their total prices.

### Level 2 Controller

#### Endpoint:

POST /level2/carts/checkout

#### Input:
- **articles**: Array of article objects containing `id`, `name`, and `price`.
- **carts**: Array of cart objects containing `id` and `items`, where each item includes `article_id` and `quantity`.
- **delivery_fees**: Optional array of delivery fee objects with transaction volume ranges and prices.
- Payload format: JSON data

#### Output:
- Returns a JSON object with the `carts` key containing an array of carts with their total prices including delivery fees.

### Level 3 Controller

#### Endpoint:

POST /level3/carts/checkout

#### Input:
- **articles**: Array of article objects containing `id`, `name`, and `price`.
- **carts**: Array of cart objects containing `id` and `items`, where each item includes `article_id` and `quantity`.
- **delivery_fees**: Optional array of delivery fee objects with transaction volume ranges and prices.
- **discounts**: Optional array of discount objects with article IDs, type (amount or percentage), and value.
- Payload format: JSON data

#### Output:
- Returns a JSON object with the `carts` key containing an array of carts with their total prices including discounts and delivery fees.

## Testing

### Running Unit Tests

To run the unit tests for the cart controllers, follow these steps:

1. Make sure you have Ruby and RSpec installed on your machine.
2. Navigate to the project directory in your terminal.
3. Run the command `rspec` to execute all unit tests.
