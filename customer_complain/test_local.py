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
        message="1977",
    ):
        print(event)
    
    
    agent_context = '{"message":{"role":"user","parts":[{"text":"1977"}]},"events":[{"content":{"role":"user","parts":[{"text":"1977"}]},"author":"GeminiEntreprise_root_agent"},{"content":{"role":"model","parts":[{"functionCall":{"name":"GeminiEntrepriseak","args":{"question":"1977"},"id":"14076651604820872102"}}]},"author":"GeminiEntreprise_root_agent","id":"14076651604820872102"}]}'
    
    for response in app.streaming_agent_run_with_events(agent_context):
        print(response)
    

if __name__ == "__main__":
    asyncio.run(main())