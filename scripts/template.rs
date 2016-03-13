#![allow(dead_code, unused_variables)]

fn show<T: std::fmt::Debug>(e: T) { println!("{:?}", e) }

fn main() {
    show({
        snippet
    });
}
