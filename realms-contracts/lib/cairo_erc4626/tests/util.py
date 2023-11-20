"""Testing utilities."""

from typing import Tuple

from starkware.starknet.public.abi import get_selector_from_name
from starkware.starknet.business_logic.execution.objects import Event

from nile.signer import Signer


TRANSACTION_VERSION = 0


def assert_event_emitted(tx_exec_info, from_address, name, data):
    assert Event(
        from_address=from_address,
        keys=[get_selector_from_name(name)],
        data=data,
    ) in tx_exec_info.raw_events


def str_to_felt(text: str) -> int:
    """Convert python string into equivalent Cairo short string value."""
    b_text = bytes(text, "UTF-8")
    return int.from_bytes(b_text, "big")


def uint(a: int) -> Tuple[int, int]:
    """Construct new uint tuple from a small number."""
    return (a, 0)


class TestSigner():
    """
    Utility for sending signed transactions to an Account on Starknet.
    Parameters
    ----------
    private_key : int
    Examples
    ---------
    Constructing a TestSigner object
    >>> signer = TestSigner(1234)
    Sending a transaction
    >>> await signer.send_transaction(
            account, contract_address, 'contract_method', [arg_1]
        )
    Sending multiple transactions
    >>> await signer.send_transaction(
            account, [
                (contract_address, 'contract_method', [arg_1]),
                (contract_address, 'another_method', [arg_1, arg_2])
            ]
        )
                           
    """
    def __init__(self, private_key):
        self.signer = Signer(private_key)
        self.public_key = self.signer.public_key
        
    async def send_transaction(self, account, to, selector_name, calldata, nonce=None, max_fee=0):
        return await self.send_transactions(account, [(to, selector_name, calldata)], nonce, max_fee)

    async def send_transactions(self, account, calls, nonce=None, max_fee=0):
        if nonce is None:
            execution_info = await account.get_nonce().call()
            nonce, = execution_info.result

        build_calls = []
        for call in calls:
            build_call = list(call)
            build_call[0] = hex(build_call[0])
            build_calls.append(build_call)

        (call_array, calldata, sig_r, sig_s) = self.signer.sign_transaction(hex(account.contract_address), build_calls, nonce, max_fee)
        return await account.__execute__(call_array, calldata, nonce).invoke(signature=[sig_r, sig_s])
