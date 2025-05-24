bool rect_rect(num x1, num y1, num w1, num h1, num x2, num y2, num w2, num h2) {
    return !(x1 + w1 < x2 || x1 > x2 + w2 || y1 + h1 < y2 || y1 > y2 + h2);
}

bool point_rect(num px, num py, num rx, num ry, num rw, num rh) {
    return (px > rx && px < rx + rw && py > ry && py < ry + rh);
}