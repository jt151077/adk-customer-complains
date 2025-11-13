import asyncio
from customer_complain.agent import root_agent
from vertexai.preview.reasoning_engines import AdkApp

async def main():

    app = AdkApp(
        agent=root_agent,
        enable_tracing=True
    )

    session = app.create_session(user_id="ysian")
    app.list_sessions(user_id="ysian")
    session = app.get_session(user_id="ysian", session_id=session.id)

    for event in app.stream_query(
        user_id="ysian",
        session_id=session.id,
        message="I am missing an item in my delivery for order id ORD2025003, the product is Ketchup",
    ):
        print(event)

if __name__ == "__main__":
    asyncio.run(main())