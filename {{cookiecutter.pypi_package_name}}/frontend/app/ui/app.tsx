"use client";

import {AppSidebar} from "@/components/app-sidebar";
import {SidebarInset, SidebarProvider, SidebarTrigger} from "@/components/ui/sidebar";
import {Separator} from "@/components/ui/separator";
import {Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card";
import {Button} from "@/components/ui/button";
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {useState} from "react";

export default function App({ user }: { user: { name: string; email: string; image: string } }) {
  const [responseText, setResponseText] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);
  const apiUrl = "/api/v1";

  const getHello = async () => {
    setLoading(true);
    try {
      const url = name ? `${apiUrl}/hello/${name}` : `${apiUrl}/hello`;
      const response = await fetch(url);
      const data = await response.json();
      setResponseText(JSON.stringify(data, null, 2));
    } catch (error) {
      setResponseText(`Error: ${error instanceof Error ? error.message : "Request failed"}`);
    } finally {
      setLoading(false);
    }
  }

  const putHello = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${apiUrl}/hello`, {
        method: 'PUT',
      });
      const data = await response.json();
      setResponseText(JSON.stringify(data, null, 2));
    } catch (error) {
      setResponseText(`Error: ${error instanceof Error ? error.message : "Request failed"}`);
    } finally {
      setLoading(false);
    }
  }

  return (
    <SidebarProvider>
      <AppSidebar user={user}/>
      <SidebarInset>
        <header className="flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12">
          <div className="flex items-center gap-2 px-4">
            <SidebarTrigger className="-ml-1" />
            <Separator
              orientation="vertical"
              className="mr-2 data-[orientation=vertical]:h-4"
            />
            <h1 className="text-base font-medium">Dashboard</h1>
          </div>
        </header>
        <div className="flex flex-1 items-center justify-center p-4">
          <Card className="w-full max-w-sm">
            <CardHeader>
              <CardTitle>Request Hello</CardTitle>
              <CardDescription>
                Click any of the buttons below to make a request to the API.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form>
                <div className="flex flex-col gap-6">
                  <div className="grid gap-2">
                    <Label htmlFor="name">Name</Label>
                    <Input
                      id="name"
                      type="text"
                      onChange={(e) => setName(e.target.value)}
                    />
                  </div>
                </div>
              </form>
            </CardContent>
            <CardContent>
              <div className="grid gap-2">
                <Label>Result</Label>
                <div className="min-h-[40px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm">
                  {loading ? "Loading..." : responseText || "No result yet..."}
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex-col gap-2">
              <Button variant="outline" className="w-full" onClick={getHello} disabled={loading}>
                GET: /api/hello
              </Button>
              <Button variant="outline" className="w-full" onClick={putHello} disabled={loading}>
                PUT: /api/hello
              </Button>
            </CardFooter>
          </Card>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
}
