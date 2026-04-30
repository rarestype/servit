public import JSON
public import SHA1

extension SHA1: @retroactive JSONStringDecodable, @retroactive JSONStringEncodable {}
