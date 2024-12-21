fn main() -> u256 {
    add(20, 30)
}

fn add(a: u256, b: u256) -> u256 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn it_works() {
        assert(add(12, 24) == 36, 'it works!');
    }
}
