## 1.0.9

- Improved the functionality of the `RelayPool` class by adding support for various message types besides `EVENT`. This enhancement allows for a more versatile use of the `RelayPool`. (Pull Request #3)

## 1.0.8

- Fixed a bug in `relay_impl` and `relay_pool_impl` that caused the first message to be skipped when calling `RelayEvent.connect`. This ensures proper addition of messages to the controller. (Pull Request #2)

## 1.0.7

- Added `isValidPrivateKey` method for the `KeyApi` class, allowing developers to validate private keys.
- Introduced `ChecksumVerificationException` for Nip19 `decode` method, providing better error handling for checksum verification.

## 1.0.6

- Resolved type casting issues with JSON data in `Metadata` class

## 1.0.4

- `SignatureVerificationException` can now be handled by the client-side. This update makes it easier for developers to catch and handle this exception without having disrupting the events coming in.

## 1.0.3

- Handling `SignatureVerificationException`

## 1.0.2

- Initial release of nostr_tools package
- Added support for nip01, nip02, nip04, nip05, nip06, and nip19
