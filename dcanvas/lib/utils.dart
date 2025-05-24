class Stack<T> {
    List<T> items = [];
    Stack();
    void push(T item) {
        items.add(item);
    }
    T pop() {
        return items.removeLast();
    }
    T top() {
        return items.last;
    }
    int size() {
        return items.length;
    }
}