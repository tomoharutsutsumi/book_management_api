# README


## Overview

The Book Management API is a Ruby on Rails application designed to manage a library’s book borrowing system. It provides endpoints for creating users, borrowing and returning books, querying user account status, and generating monthly/annual reports on user activity. Additionally, the API implements rate limiting via Rack::Attack and uses partial indexes on the transactions table for performance improvements.


## API Endpoints

### Users
- **Create User**
  - **Endpoint:** `POST /api/v1/users`
  - **Parameters:**  
    - `user[balance]` (number): The initial balance for the user.
  - **Response:** Returns the newly created user’s ID.
  - **Example:**

  ```bash
  curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user": {"balance": 100.0}}' \
  https://book-management-api-whoq.onrender.com/api/v1/users
  ```

- **Show User (Account Status)**
  - **Endpoint:** `GET /api/v1/users/:id`
  - **Response:** Returns user details such as current balance, and borrowed books.
  - **Example:**
  ```bash
  curl -X GET \                                                            
  https://book-management-api-whoq.onrender.com/api/v1/users/1
  ```

- **User Report**
  - **Endpoint:** `GET /api/v1/users/:id/reports`
  - **Query Parameter:**  
    - `period`: "monthly" or "annual"
  - **Response:**  
    - `period`: Reporting period.
    - `start_date` and `end_date`: Date range of the report.
    - `borrowed_books_count`: Number of books borrowed during that period.
    - `amount_spent`: Total fee deducted (amount spent) during that period.
  - **Example:**
  ```bash
  curl -X GET \
  "https://book-management-api-whoq.onrender.com/api/v1/users/1/reports?period=monthly"
  ```

### Transactions
- **Borrow a Book**
  - **Endpoint:** `POST /api/v1/transactions/borrow`
  - **Parameters:**  
    - `user_id`: ID of the user.
    - `book_id`: ID of the book.
  - **Response:** Returns a success message if the book is borrowed; otherwise, error messages if the book is unavailable or if the user's balance is insufficient.
  ```bash
  curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "book_id": 2}' \
  https://book-management-api-whoq.onrender.com/api/v1/transactions/borrow
  ```
  
- **Return a Book**
  - **Endpoint:** `POST /api/v1/transactions/return`
  - **Parameters:**  
    - `user_id`: ID of the user.
    - `book_id`: ID of the book.
  - **Response:** Returns a success message if the book is returned (with fee deducted), or an error if the book is not currently borrowed.
  - **Example:**
  ```bash
  curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "book_id": 2}' \
  https://book-management-api-whoq.onrender.com/api/v1/transactions/return
  ```

### Books
- **Query Book Income**
  - **Endpoint:** `GET /api/v1/books/:id/income`
  - **Query Parameters:**  
    - `start_date`: Start of the date range (YYYY-MM-DD).
    - `end_date`: End of the date range (YYYY-MM-DD).
  - **Response:** Returns the total fee income collected from return transactions for the specified book over the given period.
  - **Example:**
  ```bash
  curl -X GET \
  "https://book-management-api-whoq.onrender.com/api/v1/books/2/income?start_date=2025-03-01&end_date=2025-03-31"
  ```

### Models and Business Logic

**User Model:**

- **Account Number Generation:**  
  Uses a `before_validation` callback to auto-generate a unique account number for each user upon creation.

- **Validations:**  
  Ensures that the account number is present and unique, and that the balance is non-negative.

- **Report Generation:**  
  The `report_for` method calculates the number of borrow transactions and the total fee amount deducted within a specified period (either monthly or annual). To keep the method concise and maintainable, helper methods—such as `period_range`, `borrowed_books_count_in`, and `amount_spent_in`—are used.

- **Future Authentication:**  
  Currently, the application does not implement user authentication. However, if authentication features become necessary, I plan to integrate Devise to handle user sign-in, password management, and other authentication-related functionalities.

**Book Model:**

- **Attribute Management:**  
  Manages attributes such as the title and status of a book. The status is defined as an enum with values for `available` and `borrowed`.

- **Income Calculation:**  
  Provides an `income` method to calculate the total fee income from return transactions within a specified date range.

**Transaction Model:**

- **Transaction Recording:**  
  Records borrow and return events along with any associated fee, using an enum for transaction types (`borrow` and `return`).

- **Encapsulated Business Logic:**  
  The class methods `process_borrow!` and `process_return!` encapsulate the complete transactional workflow. This includes updating the book's status, adjusting the user's balance, and saving transaction records—all within a database transaction to ensure data consistency. This approach moves business logic from the controllers to the models, keeping controllers lean and improving testability and maintainability.

- **Performance Optimizations:**  
  Partial indexes are employed on the transactions table to optimize queries based on transaction type, in preparation for future feature enhancements. 
  Additionally, as the number of users and transactions grows, I plan to review and possibly implement record-level locking to prevent race conditions during concurrent updates.

**Rate Limiting:**

- **Rack::Attack Configuration:**  
  The API uses Rack::Attack to throttle requests based on IP address.  
  - In the test environment, the limit is set to 10 requests per minute.  
  - In production, the limit is higher.  
  This helps protect the API from abuse, including mitigating potential DDoS attacks, and ensures fair usage.

**Testing:**

- **Testing:**  
  RSpec, along with FactoryBot and Shoulda-Matchers, is used for model and request specs. These tools simplify test data setup and verify model validations and associations.

**Code Quality:**

- **RuboCop:**
To maintain code quality and consistency, RuboCop is used throughout the project. The configuration enforces best practices and coding standards, ensuring that the codebase remains clean and maintainable as the application grows.


