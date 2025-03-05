require 'rails_helper'

RSpec.describe Book, type: :model do
  it "is valid with a title" do
    book = Book.new(title: "Test Book", status: :available)
    expect(book).to be_valid
  end

  it "is invalid without a title" do
    book = Book.new(status: :available)
    expect(book).not_to be_valid
  end

  it "properly handles status enum" do
    book = Book.create!(title: "Test Book", status: :available)
    expect(book.available?).to be true
    book.borrowed!
    expect(book.borrowed?).to be true
  end
end
