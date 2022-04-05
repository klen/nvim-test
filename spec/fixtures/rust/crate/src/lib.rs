#![warn(rust_2018_idioms)]
#![cfg(feature = "full")]

mod tests {
    #[test]
    fn first_test () {
        // body
    }

    #[test]
    fn second_test () {
        // body
    }

    #[test]
    fn third_test () {
        // body
    }

    #[tokio::test]
    async fn tokio_async_test() {
        // body
    }

    #[rstest(input,
        case(1),
        case(2),
    )]
    fn rstest_test(_: u8) {
        // body
    }
}
